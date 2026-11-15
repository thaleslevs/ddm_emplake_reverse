# Pendências

## Antes da entrega

- [x] **Tirar o código decompilado do jogo original do repositório e do histórico** (feito em 14/11).
  O histórico de `main` e `checklist-completo` foi reescrito sem a pasta e enviado com force push. Quem tinha o repositório clonado precisa clonar de novo (ou `git fetch` + `git reset --hard origin/main`), senão o histórico antigo volta no próximo push.
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
