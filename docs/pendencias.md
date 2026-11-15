# Pendências

## Antes da entrega

- [x] **Tirar o código decompilado do jogo original do repositório e do histórico** (feito em 14/11).
  O histórico de `main` e `checklist-completo` foi reescrito sem a pasta e enviado com force push. Quem tinha o repositório clonado precisa clonar de novo (ou `git fetch` + `git reset --hard origin/main`), senão o histórico antigo volta no próximo push.
- [ ] **Thales: liberar o repositório para o professor.** A entrega mudou em 12/11: agora é o link do GitHub e o link do site. O repositório está privado, então o professor não consegue abrir. Duas opções (só o dono tem acesso a elas):
  - adicionar o professor como colaborador (Settings → Collaborators → Add people, com o usuário dele no GitHub); ou
  - deixar público (Settings → General → Danger Zone → Change visibility). O material do jogo original já saiu do histórico.
- [ ] **Entregar no AVA:** https://github.com/thaleslevs/ddm_emplake_reverse e https://emplake-ddm-6ab5b.web.app
- [ ] **Thales:** clonar o repositório de novo (o histórico foi reescrito em 14/11).
- [ ] **Caio:** testar o login com Google no site. O Sair e o redirecionamento para o login já foram testados.
- [x] README com link do jogo, checklist, como rodar e como usar só a pasta `lib/`.
- [x] Pacotes em `entrega/` (fora do Git): projeto completo e só a `lib/`. Não são mais exigidos; ficam como reserva.

## Visual

- [x] Criar a versão **clara** dos temas; o app começa no tema do dispositivo.
- [x] Ligar a cor semente das configurações aos acentos do tema (aba ativa, botões, navbar, foco).
- [x] Tirar o botão temporário de trocar tema (agora fica em Configurações).

## Firebase

- [x] Restringir a API key do navegador no Google Cloud Console (feito em 14/11). Sites liberados: `emplake-ddm-6ab5b.web.app`, `emplake-ddm-6ab5b.firebaseapp.com`, `localhost:8080` e `localhost:8090`. Para rodar em outra porta, acrescente o endereço lá.
- [ ] **Thales:** fechar o alerta do GitHub sobre a chave como "Won't fix" (só aparece para o dono) (a chave do Firebase web é pública por design; quem protege os dados são as regras do Firestore).
- [x] Ativar o Authentication e o provedor E-mail/senha (feito em 14/11).
- [x] Ativar o provedor Google em Authentication, com nome público "Emplake" (feito em 14/11). O ID do cliente da Web já está em `lib/core/config.dart`.
