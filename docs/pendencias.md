# Pendências

## Antes da entrega

- [ ] **Tirar o código decompilado do jogo original do repositório e do histórico.**
  A pasta `docs/referencia-original/` tem os scripts, as cenas e os screenshots do Emplake do professor (os direitos são dele). Ela entrou no primeiro commit (`798b459`) e já foi enviada ao GitHub.
  Remover só num commit novo não basta, porque continua no histórico. Passos:
  1. Guardar uma cópia local fora do repositório, se ainda for útil como referência.
  2. Reescrever o histórico sem a pasta:
     `git filter-repo --path docs/referencia-original --invert-paths`
     (instalar com `pip install git-filter-repo`).
  3. Religar o remoto (o filter-repo remove o `origin`) e fazer `git push --force origin main`.
  4. Avisar o Caio: ele precisa clonar de novo, ou fazer `git fetch` + `git reset --hard origin/main`, senão o histórico antigo volta no próximo push dele.
  5. Na seção 10 de `docs/engenharia-reversa-emplake.md`, trocar as referências à pasta por "material local, fora do repositório".
- [ ] Deixar o repositório no GitHub **privado** e adicionar o Caio como colaborador.

## Visual

- [x] Criar a versão **clara** dos temas; o app começa no tema do dispositivo.
- [x] Ligar a cor semente das configurações aos acentos do tema (aba ativa, botões, navbar, foco).
- [x] Tirar o botão temporário de trocar tema (agora fica em Configurações).

## Firebase

- [x] Restringir a API key do navegador no Google Cloud Console (feito em 14/11). Sites liberados: `emplake-ddm-6ab5b.web.app`, `emplake-ddm-6ab5b.firebaseapp.com`, `localhost:8080` e `localhost:8090`. Para rodar em outra porta, acrescente o endereço lá.
- [ ] Fechar o alerta do GitHub sobre a chave como "Won't fix" (a chave do Firebase web é pública por design; quem protege os dados são as regras do Firestore).
- [x] Ativar o Authentication e o provedor E-mail/senha (feito em 14/11).
- [x] Ativar o provedor Google em Authentication, com nome público "Emplake" (feito em 14/11). O ID do cliente da Web já está em `lib/core/config.dart`.
